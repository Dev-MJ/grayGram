//
//  PostService.swift
//  Graygram
//
//  Created by Dev.MJ on 22/03/2017.
//  Copyright © 2017 Dev.MJ. All rights reserved.
//

import Alamofire
import ObjectMapper

struct PostService {
 
  static func create(image: UIImage,
                     message: String?,
                     progress: @escaping (Progress) -> Void,  //⭐️⭐️⭐️ progress를 추적하기 위함!
                     completion: @escaping (DataResponse<Post>) -> Void){
    //새로운 포스트 만들고 업로드
    
    // ⭐️⭐️⭐️⭐️Multipart FormData - 큰 파일을 바이너리로 보낼 수 있는 형식
    let urlString = "https://api.graygram.com/posts"
    let headers: HTTPHeaders = [
      "Accept":"application/json", // 난 이 타입으로 받겠따
    ]
    
    Alamofire.upload( //multipart formdata라는 인코딩 방식을 사용하기 때문에 upload 사용
      multipartFormData: { formData in
        //formData 생성
        /*UIImage를 jpeg로 변환하여 바이너리 데이터로 변환하는 함수(이미지, 퀄리티)*/
        if let imageData = UIImageJPEGRepresentation(image, 1) {
          //이미지 업로드시에는 이 append가 좋음
          formData.append(imageData, withName: "photo"/* api에서 이미지 네임을 이렇게 받게끔 만들어져있으므로 */, fileName: "photo.jpg", mimeType: "image/jpeg")
        }
        /* string으로부터 data 생성 */
        if let messageData = message?.data(using: .utf8) {
          formData.append(messageData, withName: "message"/* api에서 텍스트는 이 이름으로 받게끔 만들어놓음 */ )
        }
    },
      to: urlString,
      headers: headers,
      encodingCompletion: { encodingResult in //multipart formdata encoding의 결과가 encodingResult로 넘어옴
        switch encodingResult {
        case .success(let request, _, _ ):
          //Alamofire.request(url)
          request //api 요청
            /*
             .uploadProgress(closure: { (<#Progress#>) in
             <#code#>
             })
             */
//            .uploadProgress{ progress in  //⭐️progress : 전체 task의 양과 현재 task의 양 다 갖고 있음
//              print("\(progress.completedUnitCount) / \(progress.totalUnitCount)")
//              //self.progressView.progress  //Float 타입. 0~1까지 지정 가능
//              //.uploadProgress에서의 UnitCount는 Int64
//              
//            }
            //.uploadProgress(closure: {(progress: Progress) -> Void in })
            .uploadProgress(closure: progress)//⭐️⭐️⭐️ escaping에서 정의한 progress와 클로져의 모양이 같으므로
            //⭐️⭐️⭐️⭐️⭐️업로드 중에 화면을 닫는다면??? 메모리에서 해제되지 않는다!
            /*
             swift는 reference counting방식 사용함.
             PostEditor에서 PostService의 create로 넘길 때 self가 넘어가면서 self의 refCount가 +1이 된다.
             그리고 PostEditor가 뜰 때 이미 +1이 되므로 총 +2가 된 상태이다.
             따라서 PostEditor가 닫혀도 refCount가 +2 - 1 = + 1 이되므로 계속 progress가 진행됨!!!
             따라서 호출 시에 약한 참조를 걸면 self가 넘어갈 때 refCount를 증가시키지 않는다!
             그러면 PostEditor를 닫으면 progress도 안됨
             */
            .validate(statusCode: 200..<400)
            .responseJSON{ response in  //response도착이 완료된 시점에 responseJSON이 호출되는것.
              
              //⭐️response.result로 switch하는 부분 제거
              
                //⭐️⭐️⭐️ responseJSON의 response를 처리하는 것이므로 responseJSON 블럭 내에서 처리해야함.
                let newResponse: DataResponse<Post> = response.flapMap{ value in  //value : Any
                  if let post = Mapper<Post>().map(JSONObject: value) {
                    return .success(post)
                  }else{
                    return .failure(MappingError(from: value, to: Post.self))
                  }
                }
              completion(newResponse)
          }
        case .failure(let error):
          print("인코딩 실패 : \(error)")  // multipart formdata를 만들지 못한 경우
          //이부분은 responseJSON 블럭 내가 아님!!!
          let response = DataResponse<Post>.init(request: nil,
                                                 response: nil,
                                                 data: nil,
                                                 result: Result<Post>.failure(error))
                                                  //post에 대한 실패상황을 넣을것.
          completion(response)
        }
    })
  }
  
  static func post(id: Int, completion: @escaping (DataResponse<Post>) -> Void) {
    let urlString = "https://api.graygram.com/posts/\(id)"
    Alamofire.request(urlString)
      .responseJSON{ response in
        let newResponse: DataResponse<Post> = response
          .flapMap({ (value) -> Result<Post> in //여기 value는 json임!!! 다른곳들도!!
            if let post = Mapper<Post>().map(JSONObject: value) {
              return Result<Post>.success(post)
            }else{
              return .failure(MappingError(from: value, to: Post.self))
            }
          })
        completion(newResponse)
    }
  }
  
  static func like(postID: Int, completion: @escaping (DataResponse<Void>) -> Void){
    
    let urlString = "https://api.graygram.com/posts/\(postID)/likes"  //post:좋아요 요청, delete: 좋아요 취소
    request(urlString, method: .post)
      .responseJSON { response in
        let newResponse: DataResponse<Void> = response.flapMap{ value in
          return Result<Void>.success(Void()) //void를 갖는 result가 newResponse로 넘어감
        }
        completion(newResponse)
    }
  }
  
  static func unlike(postID: Int, completion: @escaping (DataResponse<Void>) -> Void){
    let urlString = "https://api.graygram.com/posts/\(postID)/likes"  //post:좋아요 요청, delete: 좋아요 취소
    request(urlString, method: .delete)
      .responseJSON { response in
        let newResponse: DataResponse<Void> = response
          .flapMap{ value in
            return .success(Void())   //void를 갖는 result가 newResponse로 넘어감
        }
        completion(newResponse)
    }
  }
}
