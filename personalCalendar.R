#Create personal calendar for Owen and Thomas

courseCal <- ic_read("bb512.ics") %>% 
  arrange(DTSTART) %>% 
  mutate(Session = row_number()) %>% 
  mutate(savingsT = DTSTART < savingsTimeSwitch) %>% 
  mutate(offsetT = if_else(savingsT == TRUE, 2, 1)) %>% #Check this every year!
  mutate(DTSTART2 = DTSTART + hours(offsetT)) %>% 
  mutate(DTEND2 = DTEND + hours(offsetT)) %>% 
  mutate(Room = gsub(pattern = "Odense ",replacement = "", x = LOCATION)) %>% 
  select(Session,DTSTART2,DTEND2, Room)
courseCal

schedule <- readxl::read_excel("BB512_Schedule.xlsx")

icalSchedule <- left_join(courseCal,schedule) %>% 
  select(DTSTART2,DTEND2,Room,Type,Topic,Instructor) 

str(icalSchedule)

if(dir.exists("personalCalendar_Owen")){system("rm -r personalCalendar_Owen")}
dir.create("personalCalendar_Owen")
icalScheduleTemp <- icalSchedule %>% filter(Instructor == "OJ")
for(i in 1:nrow(icalScheduleTemp)){
icalName <- paste0("BB512_",icalScheduleTemp$DTSTART2[i])
ic_write(file = paste0("personalCalendar_Owen/",icalName,".ics") ,ic = ic_event(start = icalScheduleTemp$DTSTART2[i], 
                    end = icalScheduleTemp$DTEND2[i] , 
                    summary = paste0("BB512 ", icalScheduleTemp$Topic[i],", ", icalScheduleTemp$Type[i], " in ", icalScheduleTemp$Room[i])))
}

if(dir.exists("personalCalendar_Thomas")){system("rm -r personalCalendar_Thomas")}
dir.create("personalCalendar_Thomas")
icalScheduleTemp <- icalSchedule %>% filter(Instructor == "TBB")
for(i in 1:nrow(icalScheduleTemp)){
  icalName <- paste0("BB512_",icalScheduleTemp$DTSTART2[i])
  ic_write(file = paste0("personalCalendar_Thomas/",icalName,".ics") ,ic = ic_event(start = icalScheduleTemp$DTSTART2[i], 
                                                                                  end = icalScheduleTemp$DTEND2[i] , 
                                                                                  summary = paste0("BB512 ", icalScheduleTemp$Topic[i],", ", icalScheduleTemp$Type[i], " in ", icalScheduleTemp$Room[i])))
}

#Combine files by appending the text
files <- list.files("personalCalendar_Owen/",full.names  = TRUE)
combinedFiles <- NULL
for(i in 1:length(files)){
  temp <- readLines(con = files[i])  
  combinedFiles <- append(combinedFiles,temp)
}

#Remove the Begin/End Calendar lines.
combinedFiles[grep(pattern = "*:VCALENDAR",combinedFiles)]<-""

#Add begin/end calendar lines to the text.
combinedFiles[1] <- "BEGIN:VCALENDAR"
combinedFiles[length(combinedFiles)] <- "END:VCALENDAR"

writeLines(combinedFiles,con = "BB512_Owen.ics")

