import React from "react";
import WorkshopsActivityRow from "./WorkshopsActivityRow";
import SortPicker from "./SortPicker";
import { languageSort, lastUpdateSort } from "../../util/sortFunctions";
import StyledTable from "../shared/StyledTable";

const sortFunctions = {
  language: languageSort,
  last_update: lastUpdateSort
};

function sortActivities(sort, activities) {
  activities.sort(sortFunctions[sort.option.toLowerCase()]);
  if (!sort.asc) activities.reverse();
  return activities;
}

class WorkshopsActivitiesTable extends React.PureComponent {
  constructor(props) {
    super(props);
    this.state = {
      sort: {
        option: "Language",
        asc: true
      },
      activities: []
    };
  }

  static getDerivedStateFromProps(nextProps, prevState) {
    if (prevState.languages == nextProps.languages) return null;

    let activities = [];
    for (let language of nextProps.languages)
      activities = activities.concat(
        language.linguistic_activities.workshops_activities
      );
    sortActivities(prevState.sort, activities);
    return {
      languages: nextProps.languages,
      activities: activities
    };
  }

  changeSort = sort => {
    let activities = sortActivities(sort, this.state.activities.slice());
    this.setState({
      activities: activities,
      sort: sort
    });
  };

  render() {
    const t = this.props.t;
    const sortOptions = ["Language", "Last_update"];
    return (
      <div>
        <h3> {t("Workshops")} </h3>
        {this.state.activities.length == 0 ? (
          <p>{t("None")}</p>
        ) : (
          <SortPicker
            sort={this.state.sort}
            options={sortOptions}
            t={t}
            changeSort={this.changeSort}
          />
        )}
        <StyledTable>
          <tbody>
            {this.state.activities.map(activity => {
              return (
                <WorkshopsActivityRow
                  key={activity.id}
                  activity={activity}
                  t={t}
                />
              );
            })}
          </tbody>
        </StyledTable>
      </div>
    );
  }
}

export default WorkshopsActivitiesTable;
