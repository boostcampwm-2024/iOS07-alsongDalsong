// TODO: 녹음파일을 업로드하는 API입니다.
// Stroage에 파일을 저장하고, 해당 URL을 rooms/{RoomID}/Record Record 타입으로 저장합니다.

const { onRequest } = require('firebase-functions/v2/https');
const admin = require('../FirebaseAdmin.js');

/**
 * 음성 파일을 업로드 하는 API 입니다.
 * @param roomNumber - 방 정보
 * @param playerId - 호스트 id
 * @param round - 라운드
 * @param file - 업로드 파일
 * @returns roomData
 */
module.exports.uploadRecord = onRequest({ region: 'asia-southeast1' }, async (req, res) => {
  res.status(200).json({ message: 'Upload Record' });
});
