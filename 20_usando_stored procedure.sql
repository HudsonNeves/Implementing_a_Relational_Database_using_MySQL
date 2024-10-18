-- Chamando a procedure e passando os produtos como strings

CALL sp_InserirCompra(1, 2, '1,2', '2,1');

/* Neste exemplo:
    '1,2' são os códigos dos produtos (produto 1 e produto 2).
    '2,1' são as respectivas quantidades (produto 1 com quantidade 2, produto 2 com quantidade 1).
Esse ajuste permite que o MySQL trate múltiplos valores de produtos e suas quantidades através de strings delimitadas, já que não há suporte nativo para tabelas como parâmetros.
*/
