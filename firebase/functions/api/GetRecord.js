// TODO: 녹음파일을 가져오는 API입니다.
// IMPORTANT: 모드 별로, 라운드별로 플레이어가 가져가야할 Record를 지정해주어야합니다.

const { onRequest } = require('firebase-functions/v2/https');
const admin = require('../FirebaseAdmin.js');

/**
 * 음성 파일을 업로드 하는 API 입니다.
 * @param roomNumber - 방 번호
 * @param playerId - 호스트 id
 * @returns fileURL
 */
module.exports.uploadRecord = onRequest({ region: 'asia-southeast1' }, async (req, res) => {
  res.status(200).json({ message: 'Upload Record' });
});
