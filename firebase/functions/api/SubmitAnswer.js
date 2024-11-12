// TODO: 답을 제출하고, 음악이 맞는지 검사하는 API입니다.
// 정답은 rooms/{roomNumber}/answers 에 저장되어있습니다.
// 제출된 답이 맞는지 검사하고, 결과를 반환합니다.

const { onRequest } = require('firebase-functions/v2/https');
const admin = require('../FirebaseAdmin.js');

/**
 * 답을 제출하고, 저장된 음악이 맞는지 검사하는 HTTPS requests.
 * @param roomNumber - 방 정보
 * @param playerId - 플레이어 id
 * @param answer - 제출된 답
 * @returns Boolean
 */

module.exports.submitAnswer = onRequest({ region: 'asia-southeast1' }, async (req, res) => {
  res.status(200).json({ message: 'Submit Answer' });
});
