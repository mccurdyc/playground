// https://github.com/proxy-wasm/spec/blob/main/docs/WebAssembly-in-Envoy.md
// https://github.com/proxy-wasm/proxy-wasm-rust-sdk/blob/main/examples/hello_world/src/lib.rs
// https://content.red-badger.com/resources/extending-istio-with-rust-and-webassembly

use log::info;
use proxy_wasm as wasm;

#[unsafe(no_mangle)]
pub fn _start() {
    proxy_wasm::set_log_level(wasm::types::LogLevel::Trace);
    proxy_wasm::set_http_context(
        |context_id, _root_context_id| -> Box<dyn wasm::traits::HttpContext> {
            Box::new(HelloWorld { context_id })
        },
    )
}

struct HelloWorld {
    context_id: u32,
}

impl wasm::traits::Context for HelloWorld {}

impl wasm::traits::HttpContext for HelloWorld {
    fn on_http_request_headers(&mut self, num_headers: usize, _: bool) -> wasm::types::Action {
        info!("Got {} HTTP headers in #{}.", num_headers, self.context_id);
        let headers = self.get_http_request_headers();
        let mut authority = "";

        for (name, value) in &headers {
            if name == ":authority" {
                authority = value;
            }
        }

        self.set_http_request_header("x-hello", Some(&format!("Hello world from {}", authority)));

        wasm::types::Action::Continue
    }
}
