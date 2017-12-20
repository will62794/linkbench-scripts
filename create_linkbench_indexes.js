use linkdb0
db.linktable.createIndex({id1: 1, link_type: 1, time: 1, visibility: 1});
db.counttable.createIndex({id1: 1, link_type: 1})
