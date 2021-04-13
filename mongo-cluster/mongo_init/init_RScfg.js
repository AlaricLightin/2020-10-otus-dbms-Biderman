rs.initiate({"_id" : "RScfg",
    configsvr: true,
    members : [{"_id" : 0, priority : 3, host : "mongo_cfg_1"},
        {"_id" : 1, host : "mongo_cfg_2"},
        {"_id" : 2, host : "mongo_cfg_3"}]});