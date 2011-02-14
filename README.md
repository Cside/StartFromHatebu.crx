StartFromHatebu.crx
===================

Screenshot
----------
[![http://f.hatena.ne.jp/Cside/20110214203827](http://cdn.f.st-hatena.com/images/fotolife/C/Cside/20110214/20110214203827.png)](http://f.hatena.ne.jp/Cside/20110214203827)

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

Author
------
id:Cside (@Cside_)

