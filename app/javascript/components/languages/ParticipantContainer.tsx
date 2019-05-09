import { connect } from "react-redux";
import Activity, { IActivity } from "../../models/Activity";
import * as participantActionCreators from "../../actions/participantActions";
import { setPerson } from "../../actions/peopleActions";
import { addActivities } from "../../actions/activityActions";
import { setLanguage, addLanguages } from "../../actions/languageActions";
import { setCluster } from "../../actions/clusterActions";
import ParticipantView from "./ParticipantView";
import { AppState } from "../../reducers/appReducer";

interface IProps {
  id: number;
}

const mapStateToProps = (state: AppState, ownProps: IProps) => {
  const participant = state.participants[ownProps.id];
  if (!participant) return { participant: participant };
  return {
    participant: participant,
    person: state.people.byId[participant.person_id],
    clusterLanguage: participant.cluster_id
      ? state.clusters.get(participant.cluster_id)
      : state.languages.get(participant.language_id!),
    activities: (Object.values(state.activities) as IActivity[])
      .filter(activity => {
        return activity.participant_ids.includes(ownProps.id);
      })
      .sort(Activity.compare),
    languages: state.languages
  };
};

const mapDispatchToProps = {
  ...participantActionCreators,
  addActivities,
  setPerson,
  setLanguage,
  addLanguages,
  setCluster
};

const ParticipantContainer = connect(
  mapStateToProps,
  mapDispatchToProps
)(ParticipantView);

export default ParticipantContainer;
