-- create_tables.sql

-- Criação do schema
CREATE SCHEMA IF NOT EXISTS CASE_MELI;

-- Seleciona o banco de dados
USE CASE_MELI;

-- Criação das tabelas
CREATE TABLE CUSTOMER (
    customer_id INT PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    nome VARCHAR(255) NOT NULL,
    sobrenome VARCHAR(255) NOT NULL,
    sexo CHAR(1),
    endereco VARCHAR(255),
    data_nascimento DATE,
    telefone VARCHAR(20)
);

CREATE TABLE CATEGORY (
    category_id INT PRIMARY KEY,
    descricao VARCHAR(255) NOT NULL,
    path VARCHAR(255)
);

CREATE TABLE ITEM (
    item_id INT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    descricao TEXT,
    status VARCHAR(50),
    data_desativacao DATE,
    category_id INT,
    preco DECIMAL(10, 2),
    FOREIGN KEY (category_id) REFERENCES CATEGORY(category_id)
);

CREATE TABLE ORDERS (
    order_id INT PRIMARY KEY,
    data DATE NOT NULL,
    customer_id INT,
    valor_total DECIMAL(10, 2),
    FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id)
);

CREATE TABLE ORDER_ITEMS (
    order_id INT,
    item_id INT,
    quantidade INT,
    preco_unitario DECIMAL(10, 2),
    PRIMARY KEY (order_id, item_id),
    FOREIGN KEY (order_id) REFERENCES ORDERS(order_id),
    FOREIGN KEY (item_id) REFERENCES ITEM(item_id)
);