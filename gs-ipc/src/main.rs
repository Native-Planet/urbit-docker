use std::io::Read;
use std::io::Write;
use std::net::TcpListener;

fn main() {
    let listener = TcpListener::bind("127.0.0.1:8080").unwrap();
    for stream in listener.incoming() {
        let mut stream = stream.unwrap();
        let mut buf = [0; 1024];
        let nbytes = stream.read(&mut buf).unwrap();
        let payload = String::from_utf8_lossy(&buf[..nbytes]);

        if payload.starts_with("POST /") {
            let json = payload.split("\r\n\r\n").nth(1).unwrap();
            let mut file = std::fs::File::create("request.json").unwrap();
            file.write_all(json.as_bytes()).unwrap();
        }
    }
}