// TODO: 라운드가 업데이트 될 때 실행되는 함수
// IMPORTANT: 모드 별로 라운드 수가 다릅니다.
// 모드별로 Round가 마지막에 도착하면 Status를 result로 바꾼다.

const { onDocumentWritten } = require('firebase-functions/v2/firestore');
const admin = require('../FirebaseAdmin.js');

module.exports.onRoundEdited = onDocumentWritten(
  {
    ref: '/rooms/{roomNumber}/rounds/{round}/',
    region: 'asia-southeast1',
  },
  async (change, context) => {}
);
