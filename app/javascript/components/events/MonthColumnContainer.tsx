import { connect } from "react-redux";
import Event, { IEvent } from "../../models/Event";
import MonthColumn from "./MonthColumn";
import { AppState } from "../../reducers/appReducer";
import { IMonth } from "./dateUtils";

interface IProps {
  month: IMonth;
}

const mapStateToProps = (state: AppState, ownProps: IProps) => {
  const periodEvent = Event.comparisonEvent({
    start: ownProps.month,
    end: ownProps.month
  });
  return {
    events: (Object.values(state.events.byId) as IEvent[])
      .filter(e => Event.overlapCompare(e, periodEvent) == 0)
      .sort(Event.compare),
    people: state.people,
    languages: state.languages,
    clusters: state.clusters
  };
};

const MonthContainerColumn = connect(mapStateToProps)(MonthColumn);

export default MonthContainerColumn;
