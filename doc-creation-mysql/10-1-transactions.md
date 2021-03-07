# ДЗ 10. Транзакции. Часть 1

К сожалению, у меня пока маленький проект и в существующих рамках мне сложно придумать разумное одновременное изменение данных в нескольких таблицах, которое имело бы какой-то логический смысл, кроме, разве что, создания пользователя и назначения ему прав.

```
DELIMITER //
CREATE PROCEDURE create_admin(IN login_arg varchar(50), IN password_arg varchar(50))
BEGIN
    DECLARE id BIGINT;
    INSERT INTO users(login, password, enabled) VALUES (login_arg, password_arg, true);
    SET id = LAST_INSERT_ID();
    INSERT INTO user_authorities(user_id, authority) VALUES (id, 'ADMIN');
END;
//
DELIMITER ;
```