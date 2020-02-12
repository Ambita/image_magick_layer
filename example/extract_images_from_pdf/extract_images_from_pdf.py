import boto3
import json
import glob
import os
import re
import tempfile
from urllib.parse import unquote_plus
from subprocess import PIPE, Popen

def fix_s3_key(key):
    return unquote_plus(key)

class PDFToImages:
    def __init__(self, bucket, density=300):
        self.s3 = boto3.client('s3')
        self.bucket = bucket
        self.tempdir = tempfile.gettempdir()
        self.density = density

    def convert_file(self, image_path, image_name_stem, pdf_filename):
        convert_command = '/opt/bin/convert -density ' +\
            str(self.density) +\
            ' -background white -alpha remove ' +\
            f'\"{pdf_filename}\"' +\
            ' -quality 100 ' +\
            f'\"{image_path}/{image_name_stem}.png\"'
        process = Popen(
            args   = convert_command,
            stdout = PIPE,
            shell  = True
        )
        return process.communicate()[0]

    def _convert_to_images(self, source_filepath, image_name_stem):
        output_path = f'{self.tempdir}/images'
        try:
            os.makedirs(output_path)
        except FileExistsError:
            if not os.path.isdir(output_path):
                raise
        self.convert_file(output_path, image_name_stem, source_filepath)
        image_filenames = glob.glob(f'{output_path}/*.png')
        image_filenames.sort(
            key=lambda var: [
                int(x) if x.isdigit() else x for x in re.findall(r'[^0-9]|[0-9]+', str(var))
            ]
        )

        # We're done, return the list of images
        return image_filenames

    def extract_images(self, s3_pdf_key, image_prefix):
        pdf_filename = os.path.basename(s3_pdf_key)
        local_pdf_path = f'{self.tempdir}/{pdf_filename}'
        self.s3.download_file(self.bucket, s3_pdf_key, local_pdf_path)
        basename = pdf_filename[:-4]
        image_filenames = self._convert_to_images(local_pdf_path, basename)
        for image_filename in image_filenames:
            s3_image_key = f'{image_prefix}/{os.path.basename(image_filename)}'
            self.s3.upload_file(image_filename, self.bucket, s3_image_key)


def lambda_handler(event, context):
    bucket = os.environ['S3_BUCKET']
    image_prefix = os.environ['IMAGE_PREFIX']

    converter = PDFToImages(bucket)
    result_count = 0
    for record in event['Records']:
        s3_pdf_key = fix_s3_key(record["s3"]["object"]["key"])
        converter.extract_images(s3_pdf_key, image_prefix)
        result_count += 1

    return {
        'statusCode': 200,
        'body': json.dumps({'message': "We're done here!", 'result_count': result_count})
    }

