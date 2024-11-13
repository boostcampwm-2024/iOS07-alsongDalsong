// TODO: 유저 프로필 이미지 url 리스트를 가져오는 API 입니다.
// avatar/images/ 에 있는 이미지 url 리스트 들을 가져옵니다.

const { onRequest } = require('firebase-functions/v2/https');
const admin = require('../FirebaseAdmin.js');

/**
 * 유저 프로필 이미지 url 리스트를 가져오는 API 입니다.
 * @returns 이미지 url 리스트
 */
module.exports.getUserAvatar = onRequest({ region: 'asia-southeast1' }, async (req, res) => {
  res.status(200).json({ message: 'Get User Avatar' });
});
