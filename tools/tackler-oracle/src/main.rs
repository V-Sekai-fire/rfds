use tackler_core::kernel::Settings;
use tackler_core::parser;

fn txns(text: &str) -> Result<serde_json::Value, String> {
    let mut settings = Settings::default();
    let mut input = text;
    let data = parser::string_to_txns(&mut input, &mut settings).map_err(|e| e.to_string())?;
    let set = data.get_all().map_err(|e| e.to_string())?;
    let mut out = Vec::new();
    for t in set.txns.iter() {
        let h = &t.header;
        let posts: Vec<serde_json::Value> = t.posts.iter().map(|p| serde_json::json!({
            "account": p.acctn.atn.account.to_string(),
            "amount": p.amount.to_string(),
            "txn_commodity": p.txn_commodity.name.clone(),
            "comment": p.comment.clone(),
        })).collect();
        out.push(serde_json::json!({
            "timestamp": h.timestamp.to_string(),
            "code": h.code.clone(),
            "description": h.description.clone(),
            "uuid": h.uuid.map(|u| u.to_string()),
            "tags": h.tags.as_ref().map(|ts| ts.iter().map(|t| t.to_string()).collect::<Vec<_>>()),
            "comments": h.comments.clone(),
            "posts": posts,
        }));
    }
    Ok(serde_json::Value::Array(out))
}

fn main() {
    for path in std::env::args().skip(1) {
        let text = std::fs::read_to_string(&path).unwrap_or_default();
        let v = match txns(&text) {
            Ok(t) => serde_json::json!({"file": path, "ok": true, "txns": t}),
            Err(e) => serde_json::json!({"file": path, "ok": false, "error": e}),
        };
        println!("{v}");
    }
}
