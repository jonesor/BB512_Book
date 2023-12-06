library(tidyverse)
library(readxl)
library(janitor)
require(googledrive)

# Download from Google Drive
file <- googledrive::drive_find(pattern = "Game theory part 1", type = "spreadsheet")
file
googledrive::drive_download(
  file = googledrive::as_id(file$id),
  path = paste("data/", file$name, ".xlsx", sep = ""),
  type = "xlsx", overwrite = TRUE
)

hdg <- readxl::read_xlsx("data/Game theory part 1 (Responses).xlsx", sheet = 1) %>%
  clean_names() 

names(hdg) <- c("timestamp","teamID","round","player_1_card","player_2_card","player_1_benefit", "player_2_benefit")

hdg <- hdg %>% 
  select(teamID, round, player_1_card, player_2_card, player_1_benefit, player_2_benefit)

#Filter name errors
table(hdg$teamID)
fewRecordsTeams <- names(which(table(hdg$teamID)<10))

hdg <- hdg %>% 
  filter(!teamID %in% fewRecordsTeams)

# Does hawkishness change during the game?
hawkishness1 <- hdg %>%
  mutate(hawkNumeric_player1 = ifelse(player_1_card == "Hawk", 1, 0)) %>%
  group_by(round) %>%
  summarise(meanHawk = mean(hawkNumeric_player1))

hawkishness2 <- hdg %>%
  mutate(hawkNumeric_player2 = ifelse(player_2_card == "Hawk", 1, 0)) %>%
  group_by(round) %>%
  summarise(meanHawk = mean(hawkNumeric_player2))

hawkishness <- bind_rows(hawkishness1,hawkishness2)

ggplot(hawkishness,aes(x = round,y = meanHawk)) + 
  geom_point() + 
  geom_smooth(method = "lm") +
  ggtitle("Hawkishness doesn't decline much with\ntime for Game 1") + 
  ylim(0,1)

# How does the average hawkishness of individuals relate to the benefits received?
perIndiv_player1 <- hdg %>%
  mutate(hawkNumeric_player1 = ifelse(player_1_card == "Hawk", 1, 0)) %>%
  group_by(teamID) %>%
  summarise(mean_Hawkishness = mean(hawkNumeric_player1), mean_benefit = sum(player_1_benefit, na.rm = TRUE))

perIndiv_player2 <- hdg %>%
  mutate(hawkNumeric_player2 = ifelse(player_2_card == "Hawk", 1, 0)) %>%
  group_by(teamID) %>%
  summarise(mean_Hawkishness = mean(hawkNumeric_player2), mean_benefit = sum(player_2_benefit, na.rm = TRUE))

perIndiv_bothPlayers <- bind_rows(perIndiv_player2,perIndiv_player1)

ggplot(perIndiv_bothPlayers,aes(x = mean_Hawkishness)) + 
  geom_histogram(bins = 13) + 
  xlim(0,1) + 
  ggtitle("There is variation strategy among individuals")

ggplot(perIndiv_bothPlayers,aes(x = mean_Hawkishness,y = mean_benefit)) + 
  geom_point() + 
  stat_smooth(method="lm",formula=y~poly(x, 2),fullrange=TRUE)+
  ggtitle("The best strategy in Game 1\nis an intermediate level of hawkishness") + 
  xlim(0,1)

