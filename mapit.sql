WITH satis_join AS (SELECT magaza.magaza_kodu, magaza_ismi, magaza_tipi, satis.id, urun_adi, urun_cesidi, urun_segmenti, adet, satis_tutari_tl, yil, ay, magaza_adresi
FROM magaza
INNER JOIN satis
ON magaza.magaza_kodu = satis.magaza_kodu)

--magaza_satis_tablosu_joined
SELECT * FROM satis_join

--aylik_toplam_satis
SELECT ROW_NUMBER() OVER (ORDER BY yil, ay) AS sira_no, yil, ay, SUM(satis_tutari_tl), ROW_NUMBER() OVER (ORDER BY yil, ay) AS id
FROM satis_join
GROUP BY yil, ay
ORDER BY yil, ay

--magaza_aylik_satis_payi
SELECT 
    ROW_NUMBER() OVER (PARTITION BY yil, ay ORDER BY toplam_icindeki_payi DESC) AS sira_no,
	ROW_NUMBER() OVER (PARTITION BY yil, ay ORDER BY toplam_icindeki_payi DESC) AS id,
    yil,
    ay,
    magaza_kodu, 
    magaza_toplam_satis_tutari_tl,
    toplam_icindeki_payi
FROM (
    SELECT 
        yil,
        ay,
        magaza_kodu, 
        SUM(satis_tutari_tl) AS magaza_toplam_satis_tutari_tl,
        SUM(satis_tutari_tl) * 100 / SUM(SUM(satis_tutari_tl)) OVER (PARTITION BY yil, ay) AS toplam_icindeki_payi
    FROM satis_join
    GROUP BY yil, ay, magaza_kodu
) AS subquery
ORDER BY yil, ay, toplam_icindeki_payi DESC;

--magaza_toplam_satis_paylari
SELECT 
	ROW_NUMBER() OVER (ORDER BY magaza_kodu) AS sira_no,
    magaza_kodu, 
    SUM(satis_tutari_tl) AS magaza_toplam_satis_tutari_tl,
    SUM(satis_tutari_tl) * 100 / SUM(SUM(satis_tutari_tl)) OVER () AS toplam_icindeki_payi
FROM satis_join
GROUP BY magaza_kodu
ORDER BY toplam_icindeki_payi DESC

--tip_magaza_istatistikleri
SELECT 
    ROW_NUMBER() OVER () AS sira_no,  -- Seri numarası ekleniyor
    magaza_tipi, 
    COUNT(*) AS toplam_magaza, 
    SUM(personel_sayisi) AS toplam_personel, 
    MIN(acilis_tarihi) AS en_eski_acilis, 
    AVG(guncel_aylik_kira_tl) AS ortalama_kira, 
    AVG(magaza_alani_m2) AS ortalama_alani
FROM magaza
GROUP BY magaza_tipi;

SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'ortaklik_payi';
