import React from "react";

class TranslationActivityRow extends React.PureComponent {
  render() {
    const activity = this.props.activity;
    return (
      <tr>
        <td>
          <a href={`/programs/${activity.program_id}/`}>
            {activity.program_name}
          </a>
        </td>
        <td>
          <a href={`/activities/${activity.id}/`}>{activity.name}</a>
        </td>
        <td className="progress-cell">
          <div className="progress">
            <div
              className="progress-bar"
              role="progressbar"
              style={{
                width: `${activity.progress.percent}%`,
                backgroundColor: activity.progress.color
              }}
            />
          </div>
        </td>
        <td>{activity.stage_name}</td>
        <td className="reallySmall rightCol">
          <i>
            {this.props.strings.Updated}: {activity.last_update.slice(0, 10)}
          </i>
        </td>
      </tr>
    );
  }
}

export default TranslationActivityRow;
