
const { resizeImage } = require('./services/resizeService'); // Import resize logic
const { getImageFromS3, putImageToS3 } = require('./utils/s3Utils'); // Import S3 helpers
const AWS = require('aws-sdk');
const sns = new AWS.SNS();
 
exports.handler = async (event) => {
  try {
    const record = event.Records[0];
const bucket = record.s3.bucket.name;
    const key = decodeURIComponent(record.s3.object.key.replace(/\+/g, ' '));
 
    // Fetch the original image from S3
    const original = await getImageFromS3(bucket, key);
    
    // Resize the image using the resize service
    const resized = await resizeImage(original.Body);
 
    // Put the resized image to S3
    await putImageToS3(process.env.RESIZED_BUCKET_NAME, `resized/${key}`, resized);

    await sns.publish({
      TopicArn: process.env.SNS_TOPIC_ARN,
      Subject: 'Image Resized',
      Message: `Resized and uploaded: resized/${key}`
    }).promise();
 
    return {
      statusCode: 200,
      body: `Resized and uploaded: resized/${key}`
    };
  } catch (err) {
    console.error('Error processing image:', err);
    return {
      statusCode: 500,
      body: 'Image processing failed'
    };
  }
};
