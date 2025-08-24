//
//  SchoolManager.swift
//  311TEN022
//
//  Created by leeyeon2 on 5/1/25.
//

struct School {
    let name: String
    let range: [String]
}

// 초등학교 학년
let elementaryGrade = ["1학년", "2학년", "3학년", "4학년", "5학년", "6학년"]
// 중,고등학교 학년
let grade = ["1학년", "2학년", "3학년"]
// 기관인 경우
// 15세 ~ 34세
let age = ["8세", "9세", "10세",
           "11세", "12세", "13세", "14세", "15세", "16세", "17세", "18세", "19세", "20세",
           "21세"]

struct SchoolManager {
    
    let schools = [
        School(name: "근화초등학교", range: elementaryGrade),
        School(name: "동면청소년문화의집", range: age),
        School(name: "버들중학교", range: grade),
        School(name: "영월군청소년문화의집", range: age)
    ]
    
    // 학교명과 학년/나이를 실제 나이로 변환하는 메소드
    func convertToAge(schoolName: String, gradeOrAge: String) -> String? {
        // 학교 타입 판별
        if schoolName.contains("초등학교") {
            return convertElementaryGradeToAge(grade: gradeOrAge)
        } else if schoolName.contains("중학교") {
            return convertMiddleSchoolGradeToAge(grade: gradeOrAge)
        } else if schoolName.contains("고등학교") {
            return convertHighSchoolGradeToAge(grade: gradeOrAge)
        } else {
            // 초등학교, 중학교, 고등학교가 아닌 경우 (기관, 센터 등)
            return convertAgeStringToString(ageString: gradeOrAge)
        }
    }
    
    // 초등학교 학년을 나이로 변환 (1학년=8세, 2학년=9세, ...)
    private func convertElementaryGradeToAge(grade: String) -> String? {
        switch grade {
        case "1학년": return "8"
        case "2학년": return "9"
        case "3학년": return "10"
        case "4학년": return "11"
        case "5학년": return "12"
        case "6학년": return "13"
        default: return nil
        }
    }
    
    // 중학교 학년을 나이로 변환 (1학년=14세, 2학년=15세, 3학년=16세)
    private func convertMiddleSchoolGradeToAge(grade: String) -> String? {
        switch grade {
        case "1학년": return "14"
        case "2학년": return "15"
        case "3학년": return "16"
        default: return nil
        }
    }
    
    // 고등학교 학년을 나이로 변환 (1학년=17세, 2학년=18세, 3학년=19세)
    private func convertHighSchoolGradeToAge(grade: String) -> String? {
        switch grade {
        case "1학년": return "17"
        case "2학년": return "18"
        case "3학년": return "19"
        default: return nil
        }
    }
    
    // 나이 문자열에서 숫자만 추출하여 반환 ("20세" -> "20")
    private func convertAgeStringToString(ageString: String) -> String? {
        let numberString = ageString.replacingOccurrences(of: "세", with: "")
        // 숫자인지 확인
        if Int(numberString) != nil {
            return numberString
        }
        return nil
    }
    
    // 반대로 나이를 학교별 학년/나이 문자열로 변환하는 메소드 (필요시 사용)
    func convertAgeToGradeString(age: Int, schoolName: String) -> String? {
        if schoolName.contains("초등학교") {
            guard age >= 8 && age <= 13 else { return nil }
            return "\(age - 7)학년"
        } else if schoolName.contains("중학교") {
            guard age >= 14 && age <= 16 else { return nil }
            return "\(age - 13)학년"
        } else if schoolName.contains("고등학교") {
            guard age >= 17 && age <= 19 else { return nil }
            return "\(age - 16)학년"
        } else {
            // 초등학교, 중학교, 고등학교가 아닌 경우 (기관, 센터 등)
            guard age >= 8 && age <= 35 else { return nil }
            return "\(age)세"
        }
    }
}
