use rubbos;
load data local infile "/tmp/database/users.data" into table users fields terminated by "\t";
load data local infile "/tmp/database/stories.data" into table stories fields terminated by "\t";
load data local infile "/tmp/database/comments.data" into table comments fields terminated by "\t";
load data local infile "/tmp/database/old_stories.data" into table old_stories fields terminated by "\t";
load data local infile "/tmp/database/old_comments.data" into table old_comments fields terminated by "\t";
load data local infile "/tmp/database/submissions.data" into table submissions fields terminated by "\t";
load data local infile "/tmp/database/moderator_log.data" into table moderator_log fields terminated by "\t";

