-- Декартово произведение из несольких таблиц CROSS DJOIN

SELECT * FROM product, category;

-- Аналогично

SELECT * FROM product CROSS JOIN category;

-- Количество строк в соединении равно произведению кол-ва строк в соединяемых результатах.

-- Тета соединение (Внутренние соединение) INNER JOIN или NATURAL JOIN

SELECT p.product_name, c.category_name, p.price FROM product as p  -- product as p !!!
	INNER JOIN category as c ON p.category_id = c.category_id;


 	

-- Выведите все позиций списка товаров принадлежащие какой-либо категории с названиями товаров и названиями категорий. 
-- Список должен быть отсортирован по названию товара, названию категории. 
-- Для соединения таблиц необходимо использовать оператор INNER JOIN.


SELECT good.name, category.name FROM category_has_good
	INNER JOIN good ON category_has_good.good_id = good.id
    INNER JOIN category ON category_has_good.category_id = category.id
    ORDER BY good.name, category.name;



-- Выведите список клиентов (имя, фамилия) и количество заказов данных клиентов, имеющих статус "new".


SELECT client.first_name, client.last_name, count(1) AS new_sale_num FROM client
	INNER JOIN sale ON client.id = sale.client_id
    INNER JOIN status ON sale.status_id = status.id WHERE status.name = "new"
    GROUP BY client.first_name, client.last_name;


-- Левое и правое внешние соединения

SELECT * FROM store.category AS c lEFT OUTER JOIN store.product AS p ON p.category_id = c.category_id;

-- Запрос отдает все категории, даже если в категории отсуцтвует продукт.
-- Аналогично работает и правое внешнее соединение.

-- Объединение

SELECT * FROM product WHERE price > 900
UNION
SELECT * FROM product WHERE price < 100;

-- Запрос отдает товары которые дороже 900 и менее 100.



-- Выведите список клиентов (имя, фамилия) и количество заказов данных клиентов, имеющих статус "new"
SELECT client.first_name, client.last_name, count(1) AS new_sale_num FROM client
	INNER JOIN sale ON client.id = sale.client_id
    INNER JOIN status ON sale.status_id = status.id WHERE status.name = "new"
    GROUP BY client.first_name, client.last_name;



-- Выведите список товаров с названиями товаров и названиями категорий, в том числе товаров,
-- Не принадлежащих ни одной из категорий
SELECT good.name, category.name FROM good
	LEFT OUTER JOIN category_has_good ON good.id = category_has_good.good_id
    LEFT OUTER JOIN category ON category.id = category_has_good.category_id;



-- Выведите список товаров с названиями категорий, в том числе товаров,
-- Не принадлежащих ни к одной из категорий, в том числе категорий не содержащих ни одного товара
SELECT good.name, category.name FROM good
	LEFT OUTER JOIN category_has_good ON good.id = category_has_good.good_id
    LEFT OUTER JOIN category ON category.id = category_has_good.category_id
UNION
SELECT good.name, category.name FROM good
	RIGHT OUTER JOIN category_has_good ON good.id = category_has_good.good_id
    RIGHT OUTER JOIN category ON category.id = category_has_good.category_id;



-- Выведите список всех источников клиентов и суммарный объем заказов по каждому источнику.
-- Результат должен включать также записи для источников, по которым не было заказов
SELECT source.name, sum(sale.sale_sum) FROM source
	LEFT OUTER JOIN client ON source.id = client.source_id
    LEFT OUTER JOIN sale ON client.id = sale.client_id
    GROUP BY source.name;


-- Выведите названия товаров, которые относятся к категории 'Cakes' или фигурируют в заказах текущий статус которых 'delivering'.
-- Результат не должен содержать одинаковых записей
SELECT good.name FROM good
	INNER JOIN category_has_good ON good.id = category_has_good.good_id
    INNER JOIN category ON category.id = category_has_good.category_id WHERE category.name = "Cakes"
UNION
SELECT good.name FROM good
	INNER JOIN sale_has_good ON good.id = sale_has_good.good_id
    INNER JOIN sale ON sale.id = sale_has_good.sale_id
    INNER JOIN status ON status.id = sale.status_id WHERE status.name = "delivering";



-- Выведите список всех категорий продуктов и количество продаж товаров, относящихся к данной категории.
-- Под количеством продаж товаров подразумевается суммарное количество единиц товара данной категории, 
-- фигурирующих в заказах с любым статусом.
SELECT category.name, count(sale.id) FROM category
	LEFT OUTER JOIN category_has_good ON category.id = category_has_good.category_id
    LEFT OUTER JOIN good ON good.id = category_has_good.good_id
    LEFT OUTER JOIN sale_has_good ON good.id = sale_has_good.good_id
    LEFT OUTER JOIN sale ON sale.id = sale_has_good.sale_id
    GROUP BY category.name;



-- Выведите список источников, из которых не было клиентов, либо клиенты пришедшие из которых не совершали
-- заказов или отказывались от заказов. Под клиентами, которые отказывались от заказов, необходимо понимать
-- клиентов, у которых есть заказы, которые на момент выполнения запроса находятся в состоянии 'rejected'.
SELECT source.name FROM source
	WHERE NOT EXISTS (SELECT * FROM client WHERE client.source_id = source.id)
UNION
SELECT source.name FROM source
	INNER JOIN client ON client.source_id = source.id
    INNER JOIN sale ON sale.client_id = client.id
    INNER JOIN status ON status.id = sale.status_id WHERE status.name = "rejected";



 -- Процедуры --


 DROP PROCEDURE update_order_hitory;

 DELIMITER //
CREATE PROCEDURE update_order_hitory(
	order_id INTEGER,
	status_id INTEGER,
	sum DECIMAL(18, 2)
)
BEGIN
	DECLARE now DATETIME; -- Декларация переменной now
	SET now = NOW(); -- Установка значения переменной

	UPDATE order_history
		SET active_to = now
	WHERE order_id = order_id AND
		active_to IS NULL
	LIMIT 1;

	INSERT INTO order_history
				(order_id, status_id, sum, active_from, active_to)
			VALUES (order_id, status_id, sum, now, NULL);

END
//

-- Вызов процедуры

CALL update_order_hitory(['данные']);

-- Триггеры -- 

DELIMITER //

CREATE TRIGGER on_update_order -- Название триггера
	AFTER UPDATE -- После( или до) какого действия вызывать
	ON 'order' FOR EACH ROW -- какая таблица
BEGIN
	CALL update_order_hitory(NEW.id, NEW.status_id, NEW.sum) -- Вызов функции
END
//