# mysql 5.7 does not allow null values for fields that are primary key
# so this is a hack so migrations work
class ActiveRecord::ConnectionAdapters::Mysql2Adapter
  NATIVE_DATABASE_TYPES[:primary_key] = "int(11) auto_increment PRIMARY KEY"
end
