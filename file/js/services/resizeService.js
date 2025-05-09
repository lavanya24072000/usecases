const sharp = require('sharp');
 
exports.resizeImage = async (imageBuffer) => {
  return await sharp(imageBuffer)
    .resize(300, 300)  // Resize to 300x300 pixels (change as needed)
    .toFormat('jpeg')
    .toBuffer();
};