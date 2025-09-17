# Q11：Navigator 2.0 / RouterDelegate / RouteInformationParser 深挖

标准答案要点：
- Navigator 2.0 提供声明式路由，通过 RouterDelegate 管理导航栈并响应外部 URL（RouteInformationParser 负责解析/恢复）。

深度解析：
- 解释 RouterDelegate 的 build/notifyListeners、currentConfiguration；说明如何实现 deep-link、后退处理及页面状态恢复（Restoration）。
加分项：
- 举例说明在大型应用中如何把 RouterDelegate 与 app state（auth、onboarding）解耦；如何做 URL-to-state 双向同步。

评分细则（10分）：核心概念 4分；实现要点 4分；扩展（deep link/restore）2分
