//
//  deepseekDemo.swift
//  FeedingRecord
//
//  Created by 华子 on 2025/2/12.
//

import Foundation
import SwiftUI

struct Message {
    let role: String
    let content: String
}

struct DeepseekDemo: View {
    @State private var messages: [Message] = []
    @State private var inputText: String = ""
    private let apiKey = "sk-8b26fcbf97a14d34875d3e983a3f41ea"  // 替换为你的 API key
    
    func sendMessage() {
        print("开始发送消息...")
//        inputText = "帮我用 swift 写一个冒泡排序"
        inputText = "翻译 你好"
        // 添加用户消息到数组
        messages.append(Message(role: "system", content: inputText))
        
        guard let url = URL(string: "https://api.deepseek.com/v1/chat/completions") else {
            print("❌ URL 创建失败")
            return
        }
        
        print("📝 准备发送的消息内容: \(messages)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "model": "deepseek-chat",
            "messages": messages.map { ["role": $0.role, "content": $0.content] }
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body)
            request.httpBody = jsonData
            print("📤 发送请求体: \(String(data: jsonData, encoding: .utf8) ?? "")")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("❌ 网络错误: \(error.localizedDescription)")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 HTTP 状态码: \(httpResponse.statusCode)")
                    print("📋 响应头: \(httpResponse.allHeaderFields)")
                }
                
                if let data = data {
                    print("📥 收到响应数据: \(String(data: data, encoding: .utf8) ?? "")")
                    
                    do {
                        let json = try JSONSerialization.jsonObject(with: data)
                        print("✅ 解析后的 JSON: \(json)")
                    } catch {
                        print("❌ JSON 解析错误: \(error.localizedDescription)")
                    }
                } else {
                    print("⚠️ 没有收到响应数据")
                }
            }.resume()
            
        } catch {
            print("❌ JSON 序列化错误: \(error.localizedDescription)")
        }
    }
    
    var body: some View {
        VStack {
            TextField("输入消息", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("发送") {
                sendMessage()
            }
        }
    }
}
