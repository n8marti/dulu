import React from "react";
import PropTypes from "prop-types";
import SearchTextInput from "../shared/SearchTextInput";
import update from "immutability-helper";
import { FuzzyDateGroup } from "../shared/formGroup";
import SmallSaveAndCancel from "../shared/SmallSaveAndCancel";
import DuluAxios from "../../util/DuluAxios";
import CheckBoxInput from "../shared/CheckboxInput";
import { arrayDelete } from "../../util/arrayUtils";

export default class NewParticipantForm extends React.PureComponent {
  constructor(props) {
    super(props);
    this.state = {
      participant: {
        program_id: props.program_id,
        cluster_id: props.cluster_id,
        start_date: "",
        person_name: "",
        person_roles: [],
        roles: []
      }
    };
  }

  updateParticipant = mergeParticipant => {
    this.setState(prevState => ({
      participant: update(prevState.participant, { $merge: mergeParticipant })
    }));
  };

  addRole = role => {
    this.updateParticipant({
      roles: this.state.participant.roles.concat([role])
    });
  };

  dropRole = role => {
    this.updateParticipant({
      roles: arrayDelete(this.state.participant.roles, role)
    });
  };

  save = async () => {
    this.setState({ saving: true });
    try {
      const data = await DuluAxios.post("/api/participants", {
        participant: this.state.participant
      });
      this.props.addParticipant(data.participant);
    } catch (error) {
      this.props.setNetworkError(error);
      this.setState({ saving: false });
    }
  };

  invalid = () =>
    !this.state.participant.start_date || !this.state.participant.person_id;

  render() {
    const t = this.props.t;
    const participant = this.state.participant;

    return (
      <div>
        <SearchTextInput
          queryPath="/api/people/search"
          placeholder={t("Name")}
          updateValue={person =>
            this.updateParticipant({
              person_id: person.id,
              person_name: person.name,
              person_roles: person.roles,
              roles: person.roles.concat([])
            })
          }
          text={participant.person_name}
          autoFocus
        />
        <FuzzyDateGroup
          label={t("Start_date")}
          date={participant.start_date}
          handleDateInput={date => this.updateParticipant({ start_date: date })}
          dateIsInvalid={() => this.updateParticipant({ start_date: "" })}
          t={t}
        />
        <ul>
          {participant.person_roles.map(role => (
            <li key={role}>
              <CheckBoxInput
                value={participant.roles.includes(role)}
                text={t(`roles.${role}`)}
                handleCheck={e =>
                  e.target.checked ? this.addRole(role) : this.dropRole(role)
                }
              />
            </li>
          ))}
        </ul>
        <SmallSaveAndCancel
          handleSave={this.save}
          handleCancel={this.props.cancel}
          t={t}
          saveDisabled={this.invalid()}
          saveInProgress={this.state.saving}
        />
      </div>
    );
  }
}

NewParticipantForm.propTypes = {
  t: PropTypes.func.isRequired,
  cancel: PropTypes.func.isRequired,
  addParticipant: PropTypes.func.isRequired,
  program_id: PropTypes.number,
  cluster_id: PropTypes.number,
  setNetworkError: PropTypes.func.isRequired
};
