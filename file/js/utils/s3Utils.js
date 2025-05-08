const AWS = require('aws-sdk');
const s3 = new AWS.S3();
 
exports.getImageFromS3 = async (bucket, key) => {
  return await s3.getObject({ Bucket: bucket, Key: key }).promise();
};
 
exports.putImageToS3 = async (bucket, key, buffer) => {
  return await s3.putObject({
    Bucket: bucket,
    Key: key,
    Body: buffer,
    ContentType: 'image/jpeg'
  }).promise();
};
 