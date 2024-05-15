# 1. előkészületek #

library(tidyverse)

# adatok betöltése közvetlen linkeléréssel a d-place-ről#
# EA adatbázis #
data_ea = read_csv('https://raw.githubusercontent.com/D-PLACE/dplace-data/master/datasets/EA/data.csv', col_types = cols())
societies_ea = read_csv('https://raw.githubusercontent.com/D-PLACE/dplace-data/master/datasets/EA/societies.csv', col_types = cols())
variables_ea = read_csv('https://raw.githubusercontent.com/D-PLACE/dplace-data/master/datasets/EA/variables.csv', col_types = cols())
codes_ea = read_csv('https://raw.githubusercontent.com/D-PLACE/dplace-data/master/datasets/EA/codes.csv', col_types = cols())
# ecoClimate adatbázis #
data_eco = read_csv('https://raw.githubusercontent.com/D-PLACE/dplace-data/master/datasets/ecoClimate/data.csv', col_types = cols())
variables_eco = read_csv('https://raw.githubusercontent.com/D-PLACE/dplace-data/master/datasets/ecoClimate/variables.csv', col_types = cols())

# lakóhelyadatok behívása#
locations = read_csv('https://raw.githubusercontent.com/D-PLACE/dplace-data/master/legacy/society_locations.csv', col_types = cols())


# 2. szükséges oszlopok szelektálása #
# EA adatbázis #
data_ea = data_ea %>%
  select(soc_id, var_id, code) # törzsi azonosító, változó azonosítója, változó értéke kiválasztása #
societies_ea = societies_ea %>%
  select(id, pref_name_for_society) %>% # törzsi azonosító, törzsi megnevzés kiválasztása #
  rename(soc_id = id) # id oszlop átnevezése az egyezés érdekében #
variables_ea = variables_ea %>%
  select(id, category, title, definition) %>% # változó azonosítója, kategóriája, leírása #
  rename(var_id = id) # id oszlop átnevezése az egyezés érdekében #
# ecoClimate adatbázis #
data_eco = data_eco %>%
  select(soc_id, var_id, code) # törzsi azonosító, változó azonosítója, változó értéke kiválasztása #
variables_eco = variables_eco %>%
  select(id, category, title, definition) %>% # változó azonosítója, kategóriája, leírása #
  rename(var_id = id) # id oszlop átnevezése az egyezés érdekében #
# helyszínadatok #
locations = locations %>%
  select(soc_id, region) # törzsi azonosító, régió megnevezése #


# 3. táblázatok kombinálása egy adattáblához #
# EA táblák kombinálása #
df_long_ea = full_join(data_ea, variables_ea) %>%
  full_join(societies_ea) %>%
  full_join(codes_ea) %>%
  full_join(locations) # helyadatok hozzáadásával #
# ecoClimate táblák kombinálása #
df_long_eco = full_join(data_eco, variables_eco) %>%
  full_join(locations) # helyadatok hozzáadásával #


# 4. elemzéshez szükséges sorok szűrése #
# Unokatestvér-házasság preferálása mint változó szűrése #
# EA025 - Cousin marriages preferred #
df_long_ea = df_long_ea %>%
  filter(var_id %in% c('EA025'))

# Csapadékmennyiség kiszámíthatósága mint változó szűrése #
# PrecipitationPredictability #
df_long_eco = df_long_eco %>%
  filter(var_id %in% c('PrecipitationPredictability'))


# 5. Szűrt EA és ecoClimate táblák összekapcsolása #
# és egy kicsit szebbé varázsolása #
df_long_all = full_join(df_long_ea, df_long_eco, by = 'soc_id') %>%
  select(-region.x) %>% # kiszedtem a duplikált oszlopot#
  rename(var_id_ea = var_id.x,
         code_ea = code.x,
         category_ea = category.x,
         title_ea = title.x,
         definition_ea = definition.x,
         var_id_eco = var_id.y,
         code_eco = code.y,
         category_eco = category.y,
         title_eco = title.y,
         definition_eco = definition.y,
         region = region.y) %>% # itt pedig átneveztem a csúnya oszlopneveket #
  filter(!is.na(code_ea)) # amennyiben nincs adat az unokatestvérházassághoz, azok a sorok nem kellenek nekem #


# 6. Átláthatóbb tábla készítése csak a szükséges infókkal az elemzéshez #
df_wide_all = df_long_all %>%
  select(soc_id, pref_name_for_society, region, code_ea, code_eco, title_ea, title_eco) %>% # kiválasztottam a nekem kellő oszlopkat #
  filter(!is.na(code_ea)) 


# 7. Kapott táblák kiírása #
write_tsv(df_long_all, 'df_long_all.tsv')
write_tsv(df_wide_all, 'df_wide_all.tsv')