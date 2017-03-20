enum Result<Value> {
  case success(Value)
  case failure(Error)
}

//모나드는 map과 flatMap을 지원한다.

extension Result {
  
  //Value를 받아서 새로운 값 T 을 반환한다. Result는 그대로임
  func map<T>(_ transform: (Value) -> T) -> Result<T>{
    switch self {
    case .success(let value):
      let newValue = transform(value)
      return .success(newValue)   //새로운 값을 가지는 success를 반환
    case .failure(let error):
      return .failure(error)  //error 그대로 반환
    }
  }
  
  //Value를 받아서 새로운 Result<T>를 반환한다. Result, value 모두 바뀜
  func flatMap<T>(_ transform: (Value) -> Result<T>) -> Result<T> {
    switch self {
    case .success(let value):
      return transform(value)
    case .failure(let error):
      return .failure(error)
    }
  }
}


struct MyError: Error {}

let result = Result.success(123)
  .map{ value in
    return "\(value)"   // .success("123")    success인데, String 10을 가진 result가 됨
  }
  .map { value in
    return value.characters.reversed().map { String($0) } //.success("321")
  }
  .flatMap{ value -> Result<String> in
    return .failure(MyError())
  }

print(result)




//응용

Result<Any>.success(["id":123])
  .flatMap{ value  -> Result<[String: Any]> in
    if let json = value as? [String: Any] {
      return .success(json)
    }else{
      return .failure(MyError())
    }
  }
  .flatMap{ json -> Result<User> in
    if let user = User(json: json) {
      return .success(user)
    }else{
      return .failure(MyError)
    }
  }