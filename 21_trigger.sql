/*  trigger em MySQL para reduzir a quantidade em estoque após a inserção de uma nova compra na tabela tb_prod_comp: 
*/
DELIMITER $$

CREATE TRIGGER trg_AtualizarEstoqueCompra
AFTER INSERT ON tb_prod_comp
FOR EACH ROW
BEGIN
    -- Atualizar o estoque do produto após uma compra
    UPDATE tb_prod
    SET prod_estoque = prod_estoque - NEW.prod_comp
    WHERE prod_cod = NEW.prod_cod;

    -- Verificar se o estoque ficou negativo, e lançar um erro se isso acontecer
    IF (SELECT prod_estoque FROM tb_prod WHERE prod_cod = NEW.prod_cod) < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erro: Estoque insuficiente para o produto.';
    END IF;
END$$

DELIMITER ;

/* Analisando o script:
    Tipo de Trigger:
        Este é um trigger do tipo AFTER INSERT, o que significa que ele será executado após cada inserção na tabela tb_prod_comp.
    Atualização do Estoque:
        Para cada produto inserido em uma compra (tb_prod_comp), o estoque do produto correspondente na tabela tb_prod é atualizado, subtraindo a quantidade comprada (NEW.prod_comp).
    Validação de Estoque:
        Após atualizar o estoque, o trigger verifica se o estoque ficou negativo. Se o estoque for insuficiente (menor que zero), o trigger gera um erro usando a instrução SIGNAL, impedindo a conclusão da compra.
Como funciona:
    Ao inserir um novo item na tabela tb_prod_comp, o trigger automaticamente ajusta o estoque do produto na tabela tb_prod.
    Se o estoque não for suficiente, ele impede a inserção e gera um erro.*/

-- Removendo o 

USE `bd_caso_estudo_vendas`;

DELIMITER $$

USE `bd_caso_estudo_vendas`$$
DROP TRIGGER IF EXISTS `bd_caso_estudo_vendas`.`trg_AtualizarEstoqueCompra` $$
DELIMITER ;
