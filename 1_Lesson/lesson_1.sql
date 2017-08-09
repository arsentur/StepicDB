/* Название БД которую используем */  

use study_db;   


/* Выборка из БД */ 

select * from billing;
    where nusename == 'Petya' and sum > 900 AND currency Not in ('CHF', 'GBP');
    
/* Обновление полей БД */ 


UPDATE billing
    SET currency = 'USD';
    WHERE payer_email = 'payer@gmail.com'
    AND recepient_email = 'recipient@gmail.com'
    and sum = 500;

/* Вставка в БД  */ 


INSERT INTO billing VALUES (

'payer@gmail.com',
'recipient@gmail.com',
500, 'MYR',
'2010-08-20',
'Here are some money for you'

);



INSERT INTO billing (
    payer_email, recepient_email,
    sum, currency, billing_date) VALUES (

'payer@gmail.com',
'recipient@gmail.com',
500, 'MYR',
'2010-08-20',
'Here are some money for you'

);


/* Операции с БД */

AVG([поле]) # среднее значение 

select AVG(budget) FROM project;

/* Показывает сколько в среденем дней уходит от p_start до p_finish */
DATEDIFF(p_finish, p_start)

/* Максимальное значение */
MAX() 

/* Минимальное значение */
MIN()

SELECT 
    p_finish,
    p_start,
    DATEDIFF(p_finish, p_start) as date
FROM project;
GROUP BY client_name; # Узнать условие конкретно для клиента
ORDER BY date [DESC - сортировка в обратном порядке] # Сортировка по ...
LIMIT 10 # Лимит выборки
