FROM mongo:4.4.4-bionic

ADD init_RS1.js /scripts/init_RS1.js
ADD init_RS2.js /scripts/init_RS2.js
ADD init_RS3.js /scripts/init_RS3.js
ADD init_RScfg.js /scripts/init_RScfg.js

CMD mongo --host mongo_1_1 /scripts/init_RS1.js \
    && mongo --host mongo_2_1 /scripts/init_RS2.js \
    && mongo --host mongo_3_1 /scripts/init_RS3.js \
    && mongo --host mongo_cfg_1 /scripts/init_RScfg.js