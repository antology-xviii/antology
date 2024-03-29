insert into taxonomy (id) values ('kind');
insert into categories (taxonomy, id, ordering, description) values ('kind', 'verse', 1, '������');
insert into categories (taxonomy, id, ordering, description) values ('kind', 'drama', 2, '�����');
insert into categories (taxonomy, id, ordering, description) values ('kind', 'prose', 3, '�����');
insert into categories (taxonomy, id, ordering, description) values ('kind', 'letters', 7, '������');
insert into categories (taxonomy, id, ordering, description) values ('kind', 'memoirs', 6, '�������');
insert into categories (taxonomy, id, ordering, description) values ('kind', 'publicisticwriting', 4, '������������');
insert into categories (taxonomy, id, ordering, description) values ('kind', 'science', 5, '������������� ���������');
       
insert into taxonomy (id) values ('genre');

insert into categories (taxonomy, id, ordering, description) values ('genre', 'anacreontic�de', 1, '���������������� ���');
insert into categories (taxonomy, id, ordering, description) values ('genre', 'heroic�pera', 2, '����������� �����');
insert into categories (taxonomy, id, ordering, description) values ('genre', 'horatianOde', 3, '������������ ���');
insert into categories (taxonomy, id, ordering, description) values ('genre', 'sacredOde', 4, '�������� ���');
insert into categories (taxonomy, id, ordering, description) values ('genre', 'conundrum', 5, '�������');
insert into categories (taxonomy, id, ordering, description) values ('genre', 'idyll', 6, '������� (������, ���������)');
insert into categories (taxonomy, id, ordering, description) values ('genre', 'cantata', 7, '�������');
insert into categories (taxonomy, id, ordering, description) values ('genre', 'madrigal', 8, '��������');
insert into categories (taxonomy, id, ordering, description) values ('genre', 'inscription', 9, '�������');
insert into categories (taxonomy, id, ordering, description) values ('genre', 'songCarol', 10, '�����');
insert into categories (taxonomy, id, ordering, description) values ('genre', 'rondeau', 11, '�����');
insert into categories (taxonomy, id, ordering, description) values ('genre', 'satire', 12, '������');
insert into categories (taxonomy, id, ordering, description) values ('genre', 'sapphicOde', 13, '���������� ���');
insert into categories (taxonomy, id, ordering, description) values ('genre', 'sonnet', 14, '�����');
insert into categories (taxonomy, id, ordering, description) values ('genre', 'pindaricOde', 15, '������������� � ���������� (�������������) ���');
insert into categories (taxonomy, id, ordering, description) values ('genre', 'triolet', 16, '�������');
insert into categories (taxonomy, id, ordering, description) values ('genre', 'elegy', 17, '������');
insert into categories (taxonomy, id, ordering, description) values ('genre', 'epigram', 18, '���������');
insert into categories (taxonomy, id, ordering, description) values ('genre', 'epistle', 19, '�������� (��������)');
insert into categories (taxonomy, id, ordering, description) values ('genre', 'epitaph', 20, '��������');
insert into categories (taxonomy, id, ordering, description) values ('genre', 'fable', 21, '����� (������)');
insert into categories (taxonomy, id, ordering, description) values ('genre', 'burlesquePoem', 22, '���������� �����');
insert into categories (taxonomy, id, ordering, description) values ('genre', 'ironical-comicPoem', 23, '�����-���������� �����');
insert into categories (taxonomy, id, ordering, description) values ('genre', 'epic', 24, '����������� ����� (������)');
insert into categories (taxonomy, id, ordering, description) values ('genre', 'shortStory', 25, '�������');
insert into categories (taxonomy, id, ordering, description) values ('genre', 'narrative', 26, '�������');
insert into categories (taxonomy, id, ordering, description) values ('genre', 'novel', 27, '�����');
insert into categories (taxonomy, id, ordering, description) values ('genre', 'fairyTale', 28, '������');
insert into categories (taxonomy, id, ordering, description) values ('genre', 'comedy', 29, '�������');
insert into categories (taxonomy, id, ordering, description) values ('genre', 'comicOpera', 30, '���������� �����');
insert into categories (taxonomy, id, ordering, description) values ('genre', 'vulgarTragedy', 31, '��������� ��������');
insert into categories (taxonomy, id, ordering, description) values ('genre', 'genteelComedy', 32, '������� �������');
insert into categories (taxonomy, id, ordering, description) values ('genre', 'tragedy', 33, '��������');
insert into categories (taxonomy, id, ordering, description) values ('genre', 'treatise', 34, '�������');
insert into categories (taxonomy, id, ordering, description) values ('genre', 'oration', 35, '���� (�����)');
insert into categories (taxonomy, id, ordering, description) values ('genre', 'article', 36, '������');

insert into name_classes (name_class, description, abbreviated) values ('biblical', '���������� ���������', '����.');
insert into name_classes (name_class, description, abbreviated) values ('character', '������������ ���������', '��������');
insert into name_classes (name_class, description, abbreviated) values ('mythologic', '�������������� ���������', '���.');
insert into name_classes (name_class, description, abbreviated) values ('person', '������������ ��������', '���.');
insert into name_classes (name_class, description) values ('place', '�������������� ��������');
insert into name_classes (name_class, description, abbreviated) values ('biblicalPlace', '���������� �������������� ��������', '����.');
insert into name_classes (name_class, description, abbreviated) values ('mythologicPlace', '�������������� �������������� ��������', '���.');
insert into name_classes (name_class, description, abbreviated) values ('fictionalPlace', '������������ �������������� ��������', '���.');

insert into annotation_kinds (annotation_kind, description) values ('addressee', '�������');
insert into annotation_kinds (annotation_kind, description) values ('theme', '����');
