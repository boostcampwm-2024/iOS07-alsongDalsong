// TODO: 승자를 계산하고 Result를 나타내는 API입니다.
// rooms/{RoomID}/Scores에서 점수를 가져와 가장 높은 점수를 가진 플레이어를 리턴합니다.
// status가 result인지 검사하는 로직이 필요합니다.

const { onRequest } = require('firebase-functions/v2/https');
const admin = require('../FirebaseAdmin.js');

/**
 * 승자를 계산하고 Result를 나타내는 API 입니다.
 * @param roomNumber - 방 정보
 * @returns player
 */
module.exports.getWinner = onRequest({ region: 'asia-southeast1' }, async (req, res) => {
  res.status(200).json({ message: 'Get Result' });
});
