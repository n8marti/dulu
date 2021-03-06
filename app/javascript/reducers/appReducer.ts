import { combineReducers } from "redux";
import peopleReducer from "./peopleReducer";
import organizationsReducer from "./organizationsReducer";
import organizationPeopleReducer from "./organizationPeopleReducer";
import languagesReducer from "./languagesReducer";
import participantsReducer from "./participantsReducer";
import activitiesReducer from "./activitiesReducer";
import eventsReducer from "./eventsReducer";
import clustersReducer from "./clustersReducer";
import canReducer from "./canReducer";
import regionsReducer from "./regionsReducer";
import currentUserReducer from "./currentUserReducer";
import networkReducer from "./networkReducer";

const appReducer = combineReducers({
  languages: languagesReducer,
  clusters: clustersReducer,
  regions: regionsReducer,
  people: peopleReducer,
  organizations: organizationsReducer,
  organizationPeople: organizationPeopleReducer,
  participants: participantsReducer,
  activities: activitiesReducer,
  events: eventsReducer,
  can: canReducer,
  currentUser: currentUserReducer,
  network: networkReducer
});
export type AppState = ReturnType<typeof appReducer>;

export default appReducer;
