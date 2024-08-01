-- Tarefa 1
SELECT 
    C.customer_id,
    C.nome,
    C.sobrenome,
    COUNT(O.order_id) AS total_vendas
FROM 
    CUSTOMER C
LEFT JOIN 
    ORDERS O ON C.customer_id = O.customer_id
WHERE 
    MONTH(C.data_nascimento) = MONTH(CURDATE()) 
    AND DAY(C.data_nascimento) = DAY(CURDATE())
    AND MONTH(O.data) = 1 
    AND YEAR(O.data) = 2020
GROUP BY 
    C.customer_id, C.nome, C.sobrenome
HAVING 
    total_vendas > 1500;
    
-- Tarefa 2
WITH RANKED_SALES AS (
    SELECT 
        YEAR(O.data) AS ano,
        MONTH(O.data) AS mes,
        C.nome,
        C.sobrenome,
        COUNT(O.order_id) AS quantidade_vendas, -- quantidade de order_ids distintos
        SUM(OI.quantidade) AS quantidade_produtos_vendidos,
        SUM(OI.quantidade * OI.preco_unitario) AS total_transacionado,
        ROW_NUMBER() OVER (PARTITION BY YEAR(O.data), MONTH(O.data) ORDER BY SUM(OI.quantidade * OI.preco_unitario) DESC) AS ranked_sales
    FROM 
        ORDERS O
    LEFT JOIN 
        ORDER_ITEMS OI ON O.order_id = OI.order_id
    LEFT JOIN 
        ITEM I ON OI.item_id = I.item_id
    LEFT JOIN 
        CATEGORY CA ON I.category_id = CA.category_id
    LEFT JOIN 
        CUSTOMER C ON O.customer_id = C.customer_id
    WHERE 
        YEAR(O.data) = 2020
        AND CA.descricao = 'Celulares'
    GROUP BY 
        YEAR(O.data), MONTH(O.data), C.customer_id
)
SELECT 
    ano,
    mes,
    nome,
    sobrenome,
    quantidade_vendas,
    quantidade_produtos_vendidos,
    total_transacionado
FROM 
    RANKED_SALES
WHERE 
    ranked_sales <= 5
ORDER BY 
    ano, mes, ranked_sales;
    
-- Tarefa 3
-- Criação da nova tabela

USE CASE_MELI;

CREATE TABLE ITEM_DAILY_STATUS (
    item_id INT,
    data DATE,
    preco DECIMAL(10, 2),
    status VARCHAR(50),
    PRIMARY KEY (item_id, data)
);

-- Procedimento armazenado
DELIMITER $$

CREATE PROCEDURE PopulateItemDailyStatus()
BEGIN
    -- Insere ou atualiza os dados na tabela ITEM_DAILY_STATUS
    INSERT INTO ITEM_DAILY_STATUS (item_id, data, preco, status)
    SELECT 
        item_id, 
        CURDATE(), 
        preco, 
        status
    FROM 
        ITEM
    ON DUPLICATE KEY UPDATE
        preco = VALUES(preco),
        status = VALUES(status);
END $$

DELIMITER ;

-- Cria um evento agendado para executar o procedimento diariamente à meia-noite
CREATE EVENT PopulateItemDailyStatusEvent
ON SCHEDULE EVERY 1 DAY
STARTS '2024-07-29 23:59:59'
DO
CALL PopulateItemDailyStatus();
