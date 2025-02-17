/*
Para criar uma stored procedure no SQL Server para o banco de dados que você forneceu, um exemplo que insira uma nova compra na tabela tb_compra, 
associando-a a um cliente (tb_cli) e a um funcionário (tb_func), além de vincular os produtos comprados na tabela tb_prod_comp.
*/

DELIMITER $$

CREATE PROCEDURE sp_InserirCompra(
    IN cli_cod INT,
    IN func_cod INT,
    IN produtos_cod VARCHAR(255),
    IN produtos_quant VARCHAR(255)
)
BEGIN
    DECLARE compra_cod INT;
    DECLARE prod_cod INT;
    DECLARE quantidade INT;
    DECLARE idx INT DEFAULT 1;
    DECLARE prod_cod_str VARCHAR(10);
    DECLARE quant_str VARCHAR(10);

    -- Iniciar transação
    START TRANSACTION;

    -- Inserir a compra
    INSERT INTO tb_compra (compra_cli_cod, compra_func_cod, compra_qtd_prod)
    VALUES (cli_cod, func_cod, (
        SELECT SUM(CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(produtos_quant, ',', idx), ',', -1) AS UNSIGNED))
        FROM (SELECT @idx:=@idx+1 FROM information_schema.tables) subquery
        WHERE idx <= (LENGTH(produtos_quant) - LENGTH(REPLACE(produtos_quant, ',', '')) + 1)
    ));

    -- Obter o código da compra recém-inserida
    SET compra_cod = LAST_INSERT_ID();

    -- Laço para inserir os produtos
    WHILE idx <= (LENGTH(produtos_cod) - LENGTH(REPLACE(produtos_cod, ',', '')) + 1) DO
        -- Extrair o código do produto
        SET prod_cod_str = SUBSTRING_INDEX(SUBSTRING_INDEX(produtos_cod, ',', idx), ',', -1);
        SET prod_cod = CAST(prod_cod_str AS UNSIGNED);

        -- Extrair a quantidade do produto
        SET quant_str = SUBSTRING_INDEX(SUBSTRING_INDEX(produtos_quant, ',', idx), ',', -1);
        SET quantidade = CAST(quant_str AS UNSIGNED);

        -- Inserir o produto na tabela tb_prod_comp
        INSERT INTO tb_prod_comp (compra_cod, prod_cod, prod_comp)
        VALUES (compra_cod, prod_cod, quantidade);

        -- Incrementar o índice
        SET idx = idx + 1;
    END WHILE;

    -- Confirmar transação
    COMMIT;

    -- Confirmação de sucesso
    SELECT 'Compra inserida com sucesso.';

END$$

DELIMITER ;

/* Analisando o script:
    Parâmetros:
        produtos_cod: Uma string delimitada por vírgulas contendo os códigos dos produtos (ex: '1,2,3').
        produtos_quant: Uma string delimitada por vírgulas contendo as quantidades correspondentes (ex: '2,1,4').
    Inserção da Compra:
        A compra é inserida na tabela tb_compra, e o total de produtos é calculado a partir da string de quantidades.
    Loop para Inserção de Produtos:
        Utilizamos um laço WHILE para percorrer os produtos e quantidades, e inserimos na tabela tb_prod_comp.
    Transação:
        Utilizamos START TRANSACTION e COMMIT para garantir que a operação seja atômica. */
