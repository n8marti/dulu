import React from "react";
import PropTypes from "prop-types";
import Activity from "../../models/Activity";
import { Link } from "react-router-dom";
import WorkshopActivity from "../workshops/WorkshopActivity";
import update from "immutability-helper";
import { replace } from "../../util/arrayUtils";
import ActivityView from "./ActivityView";

export default class LanguageActivityPage extends React.PureComponent {
  activity = () =>
    Activity.findActivity(this.props.language, this.props.activityId);

  replaceWorkshopsActivity = activity => {
    this.props.replaceLanguage(
      update(this.props.language, {
        workshops_activities: {
          $set: replace(this.props.language.workshops_activities, activity)
        }
      })
    );
  };

  render() {
    const t = this.props.t;
    const language = this.props.language;
    const activity = this.activity();

    return (
      <div>
        <h4>
          <Link to={this.props.basePath}>{`< ${language.name}`}</Link>
        </h4>
        {/* <EditActionBar
          can={this.props.can}
          editing={this.state.editing}
          saving */}
        <h2>{Activity.name(activity, t)}</h2>
        {Activity.isWorkshops(activity) ? (
          <WorkshopActivity
            activity={activity}
            t={t}
            can={language.can}
            replaceActivity={this.replaceWorkshopsActivity}
            setNetworkError={this.props.setNetworkError}
            language={language}
          />
        ) : (
          <ActivityView
            basePath={this.props.basePath}
            language={language}
            activity={activity}
            t={t}
          />
        )}
      </div>
    );
  }
}

LanguageActivityPage.propTypes = {
  t: PropTypes.func.isRequired,
  language: PropTypes.object.isRequired,
  activityId: PropTypes.string.isRequired,
  basePath: PropTypes.string.isRequired,
  replaceLanguage: PropTypes.func.isRequired,
  setNetworkError: PropTypes.func.isRequired
};
