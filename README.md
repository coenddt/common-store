# common-store

**一套 JSON schema、一种 GQL 方言，跑通 MongoDB / MySQL / SQLite / PostgreSQL / 本地磁盘（local）—— Node.js 与 Python 共用同一个 Rust 内核。**

（1 段定位：纯 JSON 定义模型；嵌套关系编译成后端单条原生查询，不用手写 $lookup / JOIN；
  内置 RBAC、计算列、软删除；语义只实现一次，故 Node/Python 行为不漂移。）

## 一键开始

### Node.js
```bash
npx create-store-app myapp
cd myapp && npm install && npm start      # REST 起在 :3000
```

### Python
```bash
npx create-store-app myapp --lang python
cd myapp && pip install -e . && python impl/bootstrap.py
```

> 前置：一个本地 MongoDB（默认 `mongodb://127.0.0.1:27017`，库名 = 应用名）。
> 协议皮由 `--skins rest,graphql,grpc` 选择（至少 1 个，缺省 `rest`）。
> ⚠️ Python 路径当前依赖 `store-gateway-py`，该包**尚未发布 PyPI**（见「已知缺口」）。

## 这是什么（分层）

| 层 | 组件 | 职责 |
|---|---|---|
| 引擎 | `rust-store-core` | GQL 解析 / 权限 / 计算列 / 命令规划 / SQL 方言；无 IO |
| 绑定 | `rust-store-node` / `rust-store-py` / `core-ffi` | 把引擎暴露给各语言 |
| 宿主 | `nodejs-store` / `storepy` / `go-store` | 驱动 IO、回调注入、占位符替换 |
| 协议皮 | `store-api` / `store-graphql` / `store-grpc` / `store-mcp` + `store-gateway` | REST / GraphQL / gRPC / MCP 面 |
| 控制面 | `meta-store` | schema 定义的发布 / 列表 / 回滚 |
| 脚手架 | `create-store-app` | 一键生成数据驱动应用 |

## 包矩阵

| 组件 | Node.js | Python | Rust |
|---|---|---|---|
| 引擎 | — | — | `rust-store-core` 4.0.0（crates.io） |
| 绑定 | `rust-store-node` 4.0.0（npm） | `rust-store-py` 4.0.0（PyPI） | `core-ffi`（仓内，C ABI） |
| 宿主 | `nodejs-store` 4.0.0（npm） | `storepy` 4.0.0（PyPI，import `py_store`） | `go-store`（仓内，Go 宿主 v0，SQLite） |

> 两宿主（nodejs-store / storepy）均内置 `local` 后端（零外部服务、零原生 DB 引擎）。
| REST 皮 | `store-api-node` 0.1.0 | `store-api-py` 0.1.0 | — |
| GraphQL 皮 | `store-graphql-node` 0.1.0 | `store-graphql-py` 0.1.0 | — |
| gRPC 皮 | `store-grpc-node` 0.1.0 | `store-grpc-py` 0.1.0 | — |
| MCP 皮 | `store-mcp-node` 0.1.0 | `store-mcp-py` 0.1.0 | — |
| 协议组合器 | `store-gateway-node` 0.1.0 | `store-gateway-py` **未发布** | — |
| 脚手架 | `create-store-app` 0.2.0（npm） | 同左（`--lang python`） | — |

## 三种用法

1. **直接用宿主库** —— `pip install storepy` / `npm i nodejs-store`，schema 用纯 JSON，查询用 GQL。
2. **起协议面** —— 由 `create-store-app --skins ...` 生成，经 `store-gateway-*` 组合 REST/GraphQL/gRPC。
3. **AI 问数** —— `store.ask(question, llm=..., ctx=...)`：自然语言 → GQL+params → 受控沙箱执行。

## 文档

- Python 宿主：https://coenddt.github.io/py-store/ · 仓库 https://github.com/coenddt/py-store
- Node.js 宿主：https://github.com/coenddt/nodejs-store （npm `nodejs-store`）
- 引擎 core：https://coenddt.github.io/rust-store/ · 仓库 https://github.com/coenddt/rust-store

## 已知缺口

- `store-gateway-py` 未发布 PyPI ⇒ Python 一键流程 `pip install -e .` 会失败（其余 Python 依赖
  `storepy` / `store-api-py` / `store-graphql-py` / `store-grpc-py` 均已发布）。

## License

MIT
