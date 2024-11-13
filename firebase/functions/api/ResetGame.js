// TODO: 게임 리셋 요청하는 API입니다.
// rooms/{roomNumber}의 status를 초기화합니다.
// 방의 호스트가 호출했는지 검사하는 로직이 필요합니다.

const { onRequest } = require('firebase-functions/v2/https');
const admin = require('../FirebaseAdmin.js');

/**
 * 게임을 리셋 요청을 하는 HTTPS requests.
 * @param roomNumber - 방 정보
 * @param playerId - 호스트 id
 * @returns Boolean
 */

module.exports.resetGame = onRequest({ region: 'asia-southeast1' }, async (req, res) => {
  res.status(200).json({ message: 'Reset Game' });
});
