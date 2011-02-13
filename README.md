StartFromHatebu.crx
===================

Descriptin
----------
Chromeのスタートページをはてなブックマークのマイブックマーク一覧にする。検索も可能。

How to Use
----------

    git clone git://github.com/Cside/StartFromHatebu.crx.git
    cd StartFromHatebu.crx/
    cpanm Module::Install Module::Install::AuthorTests
    cpanm --installdeps .
    perl -MConfig::Pit -e'Config::Pit::set("hatena.ne.jp", data=>{ username => "username on Hatena", password => "password" })'
    plackup -p 5000 app.psgi

これで使えるようになります。
ポートは5000番である必要はありません。
ただし5000番以外のポートを使う際はオプションページからURLの変更を行ってください。
オプションページは chrome://extensions/ にアクセスして探すと見つかります。

TODO
----
 * 検索結果が20件以上のときのMoreモードの実装
 * いい感じのファビコン
 * キャッシュの長さの指定をオプションページからできるように

Author
------
id:Cside (@Cside_)
