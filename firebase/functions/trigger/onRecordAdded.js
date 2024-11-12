// TODO: 레코드가 생성되거나 업데이트 될 때 실행되는 함수
// IMPORTANT: 모드 별로 라운드와 Status를 변경하는 방법이 다릅니다.
// 레코드가 생성될 경우 모드에 따라 라운드와 Status 상태를 변경한다.
// 라운드 마다 녹음 파일의 갯수를 검사하여 모든 플레이어가 녹음을 완료했을 경우 다음 라운드로 넘어간다.
// 마지막 라운드가 끝나면 결과 Status로 변경한다.

const { onDocumentWritten } = require('firebase-functions/v2/firestore');
const admin = require('../FirebaseAdmin.js');

module.exports.onRecordAdded = onDocumentWritten(
  {
    ref: '/rooms/{roomNumber}/records/{round}/',
    region: 'asia-southeast1',
  },
  async (change, context) => {}
);
