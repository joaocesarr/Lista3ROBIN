USE BD044152
GO

-- Exercicio 11

CREATE PROCEDURE GetProductByName (@Name varchar(150))
AS
BEGIN
  SELECT p.ProdutoID, p.Descricao, m.Descricao
  FROM Produto AS p
  INNER JOIN Marca AS m ON p.MarcaID = m.MarcaID
  WHERE p.Descricao LIKE '%' + @Name + '%';
END;
GO

EXEC GetProductByName 'Camiseta'

--DROP PROCEDURE GetProductByName

-- Exercico 12
GO
CREATE PROCEDURE Get_VendaMarca_By_Venda @Sale int = NULL
AS

    IF (EXISTS (SELECT * 
                    FROM INFORMATION_SCHEMA.TABLES 
                    WHERE TABLE_NAME = '#VendaMarca'))
    BEGIN
        DROP TABLE #VendaMarca
    END
    
    SELECT
        m.MarcaID,
        m.Descricao,
        SUM(vp.PrecoVenda) AS TotalVendido
    INTO 
        #VendaMarca
    FROM
        Marca AS m
        INNER JOIN Produto AS p
        ON p.MarcaID = m.MarcaID
        INNER JOIN VendaProduto AS vp
        ON p.ProdutoID = vp.ProdutoID
    GROUP BY  m.MarcaID,m.Descricao;
    
    SELECT * 
    FROM #VendaMarca
    WHERE 1=1
        AND @Sale IS NULL
        OR TotalVendido = @Sale
GO    
-- EXEC Get_VendaMarca_By_Venda 323
-- DROP PROCEDURE Get_VendaMarca_By_Venda

-- Exercicio 13

CREATE FUNCTION Get_VendaProduto_By_Venda(@Sale int = NULL)
RETURNS TABLE
AS
RETURN (
    SELECT * 
        FROM (
            SELECT
                p.ProdutoID,
                p.Descricao,
                COUNT(vp.PrecoVenda) AS QntdVendido
            FROM
                Produto AS p
                INNER JOIN VendaProduto AS vp
                ON p.ProdutoID = vp.ProdutoID
            GROUP BY  p.ProdutoID,p.Descricao
        ) AS VendaProduto
        WHERE 1=1
            AND @Sale IS NULL
            OR VendaProduto.QntdVendido >= @Sale
)
GO
SELECT * FROM Get_VendaProduto_By_Venda(DEFAULT)
-- DROP FUNCTION Get_VendaProduto_By_Venda

-- Exercicio 14
GO
CREATE FUNCTION Get_Cliente_By_Cidade(@City varchar(150) = NULL)
RETURNS TABLE
AS
RETURN (
    SELECT 
        c.Nome,
        cd.Descricao
    FROM EnderecoCliente AS ec
        INNER JOIN Cliente AS c
        ON c.ClienteID = ec.ClienteID
        INNER JOIN Cidade AS cd
        ON cd.CidadeID = ec.CidadeID
        LEFT JOIN Venda AS v    
        ON c.ClienteID = v.VendaID
    WHERE 1=1
        AND v.VendaID IS NULL
        AND @City IS NULL
        OR cd.Descricao LIKE '%' + @City + '%'
)
GO
SELECT * FROM Get_Cliente_By_Cidade('São')
-- DROP FUNCTION Get_Cliente_By_Cidade
-- SELECT TOP(10) * FROM Venda

-- Exercicio 15
GO
CREATE TRIGGER Alter_Brand_Product
ON Marca
AFTER UPDATE
AS BEGIN
    IF UPDATE(Descricao)
    BEGIN
        DECLARE 
            @Desc VARCHAR(255),
            @Brand VARCHAR(255)
        SELECT @Desc = REPLACE(Descricao, ' LIVRE 08/17', ' ')FROM INSERTED
        SELECT @Brand = REPLACE(Descricao, ' LIVRE 08/17', ' ') FROM DELETED
        PRINT(@Desc)
        PRINT(@Brand)

        UPDATE Produto
            SET Descricao = REPLACE(Descricao, @Brand, @Desc)
            WHERE 1=1
                AND Descricao LIKE '%' + @Brand + '%' 
    END
END
GO

UPDATE Marca
    SET Descricao = 'UP MAN'
    WHERE MarcaID = 366

SELECT TOP(10) 
    m.MarcaID,
    m.Descricao,
    p.Descricao
    FROM Produto AS p
        INNER JOIN Marca AS m
        ON m.MarcaID = p.MarcaID
    WHERE 1=1
        AND m.MarcaID = 366

-- SELECT TOP(10) * FROM Marca
-- DROP TRIGGER Alter_Brand_Product

 -- Exercicio 16
CREATE TABLE LOGPRODUTO (
    IdProduto INT,
    DataAtual DATETIME
);
GO
CREATE TRIGGER trgVendaProdutoSaldoZero
ON dbo.VendaProduto
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;


    INSERT INTO LOGPRODUTO (IdProduto, DataAtual)
    SELECT i.ProdutoID, GETDATE()
    FROM inserted i
    INNER JOIN dbo.Produto p ON p.ProdutoID = i.ProdutoID
    WHERE p.Estoque <= 0;
END;

-- Exercicio 17

ALTER TABLE Grupo
ADD Ativo bit 

-- UPDATE Grupo SET Ativo = 1

-- SELECT * FROM Grupo
GO
CREATE TRIGGER Not_Del_Group
ON Grupo
INSTEAD OF DELETE
AS BEGIN
    UPDATE Grupo
    SET Ativo = 0
    WHERE GrupoID = ( SELECT GrupoID FROM DELETED )
END
GO

DELETE Grupo WHERE GrupoID = 12