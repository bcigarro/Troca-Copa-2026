-- Base temporaria e mockada para o MVP, alinhada aos totais divulgados pela Panini:
-- 980 cromos, 48 selecoes, 68 especiais e 112 paginas.
-- Substitua nomes de jogadores/codigos pela checklist oficial validada quando necessario.
with teams(team_order, team_name, team_code) as (
  values
    (1, 'Mexico', 'MEX'), (2, 'Marrocos', 'MAR'), (3, 'Coreia do Sul', 'KOR'), (4, 'Escocia', 'SCO'),
    (5, 'Canada', 'CAN'), (6, 'Suica', 'SUI'), (7, 'Bosnia e Herzegovina', 'BIH'), (8, 'Catar', 'QAT'),
    (9, 'Argentina', 'ARG'), (10, 'Argelia', 'ALG'), (11, 'Austria', 'AUT'), (12, 'Haiti', 'HAI'),
    (13, 'Estados Unidos', 'USA'), (14, 'Turquia', 'TUR'), (15, 'Paraguai', 'PAR'), (16, 'Australia', 'AUS'),
    (17, 'Alemanha', 'GER'), (18, 'Equador', 'ECU'), (19, 'Costa do Marfim', 'CIV'), (20, 'Curacao', 'CUW'),
    (21, 'Paises Baixos', 'NED'), (22, 'Japao', 'JPN'), (23, 'Suecia', 'SWE'), (24, 'Tunisia', 'TUN'),
    (25, 'Belgica', 'BEL'), (26, 'Egito', 'EGY'), (27, 'Ira', 'IRN'), (28, 'Nova Zelandia', 'NZL'),
    (29, 'Espanha', 'ESP'), (30, 'Uruguai', 'URU'), (31, 'Arabia Saudita', 'KSA'), (32, 'Cabo Verde', 'CPV'),
    (33, 'Franca', 'FRA'), (34, 'Noruega', 'NOR'), (35, 'Senegal', 'SEN'), (36, 'Iraque', 'IRQ'),
    (37, 'Brasil', 'BRA'), (38, 'Africa do Sul', 'RSA'), (39, 'Chequia', 'CZE'), (40, 'Jordania', 'JOR'),
    (41, 'Portugal', 'POR'), (42, 'Colombia', 'COL'), (43, 'RD Congo', 'COD'), (44, 'Uzbequistao', 'UZB'),
    (45, 'Inglaterra', 'ENG'), (46, 'Croacia', 'CRO'), (47, 'Gana', 'GHA'), (48, 'Panama', 'PAN')
),
intro as (
  select case when n = 1 then '00' else 'FWC' || (n - 1)::text end as code, n as number,
    case when n <= 8 then 'Abertura oficial ' || n::text else 'FIFA Museum ' || (n - 8)::text end as name,
    null::text as team, case when n <= 8 then 'Abertura' else 'FIFA Museum' end as category,
    'especial' as type, n as sort_order, true as is_special
  from generate_series(1, 20) as n
),
team_stickers as (
  select team_code || local_number::text as code, 20 + ((team_order - 1) * 20) + local_number as number,
    case when local_number = 1 then 'Escudo - ' || team_name when local_number = 2 then 'Foto da selecao - ' || team_name else 'Jogador ' || (local_number - 2)::text || ' - ' || team_name end as name,
    team_name as team,
    case when local_number = 1 then 'Escudos' when local_number = 2 then 'Foto da selecao' else 'Jogadores' end as category,
    case when local_number = 1 then 'especial' else 'comum' end as type,
    20 + ((team_order - 1) * 20) + local_number as sort_order,
    local_number = 1 as is_special
  from teams cross join generate_series(1, 20) as local_number
), seed as (select * from intro union all select * from team_stickers)
insert into public.stickers (code, number, name, team, category, type, sort_order, is_special)
select code, number, name, team, category, type, sort_order, is_special from seed
on conflict (code) do update set number = excluded.number, name = excluded.name, team = excluded.team, category = excluded.category, type = excluded.type, sort_order = excluded.sort_order, is_special = excluded.is_special;
