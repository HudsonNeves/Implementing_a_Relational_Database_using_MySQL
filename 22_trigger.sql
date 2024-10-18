DELIMITER $$

CREATE TRIGGER trg_AtualizarEstoqueCompra
AFTER INSERT ON tb_prod_comp
FOR EACH ROW
BEGIN
    -- Atualizar o estoque do produto após a inserção de uma compra
    UPDATE tb_prod
    SET prod_estoque = prod_estoque - NEW.prod_comp
    WHERE prod_cod = NEW.prod_cod;

    -- Verificar se o estoque ficou negativo e, se sim, lançar um erro
    IF (SELECT prod_estoque FROM tb_prod WHERE prod_cod = NEW.prod_cod) < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erro: Estoque insuficiente para o produto.';
    END IF;
END$$

DELIMITER ;
