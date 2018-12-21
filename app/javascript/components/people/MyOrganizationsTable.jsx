import React from "react";
import MyOrganizationsTableRow from "./MyOrganizationsTableRow";
import { findIndexById } from "../../util/arrayUtils";
import update from "immutability-helper";
import SearchTextInput from "../shared/SearchTextInput";
import SmallSaveAndCancel from "../shared/SmallSaveAndCancel";
import DuluAxios from "../../util/DuluAxios";
import InlineAddIcon from "../shared/icons/InlineAddIcon";

export default class MyOrganizationsTable extends React.PureComponent {
  state = {};

  createOrganizationPerson = async () => {
    try {
      if (!this.state.newOrganization) return;
      const organizationPerson = {
        person_id: this.props.person.id,
        organization_id: this.state.newOrganization.id
      };
      const data = await DuluAxios.post("/api/organization_people", {
        organization_person: organizationPerson
      });
      const newOrganizationPerson = data.organization_person;
      this.props.replaceOrganizationPeople(
        update(this.props.person.organization_people, {
          $push: [newOrganizationPerson]
        })
      );
      this.setState({ addingNew: false });
    } catch (error) {
      this.props.setNetworkError({ tryAgain: this.createOrganizationPerson });
    }
  };

  replaceOrganizationPerson = organizationPerson => {
    this.props.replaceOrganizationPeople(
      update(this.props.person.organization_people, {
        [findIndexById(
          this.props.person.organization_people,
          organizationPerson.id
        )]: { $set: organizationPerson }
      })
    );
  };

  deleteOrganizationPerson = async id => {
    try {
      await DuluAxios.delete(`/api/organization_people/${id}`);
      const index = findIndexById(this.props.person.organization_people, id);
      this.props.replaceOrganizationPeople(
        update(this.props.person.organization_people, {
          $splice: [[index, 1]]
        })
      );
    } catch (error) {
      this.props.setNetworkError({
        tryAgain: () => this.deleteOrganizationPerson(id)
      });
    }
  };

  render() {
    return (
      <div>
        <h3>
          {this.props.t("Organizations")}
          {this.props.person.can.update && (
            <InlineAddIcon onClick={() => this.setState({ addingNew: true })} />
          )}
        </h3>
        <table>
          <tbody>
            {this.props.person.organization_people.map(org_person => (
              <MyOrganizationsTableRow
                key={org_person.id}
                t={this.props.t}
                canUpdate={this.props.person.can.update}
                editing={this.props.editing}
                org_person={org_person}
                replaceOrganizationPerson={this.replaceOrganizationPerson}
                deleteOrganizationPerson={this.deleteOrganizationPerson}
                setNetworkError={this.props.setNetworkError}
              />
            ))}
            {this.state.addingNew && (
              <tr>
                <td colSpan="4">
                  <SearchTextInput
                    updateValue={org => this.setState({ newOrganization: org })}
                    queryPath="/api/organizations/search"
                    text={
                      this.state.newOrganization
                        ? this.state.newOrganization.name
                        : ""
                    }
                    autoFocus
                    allowBlank
                  />
                  <SmallSaveAndCancel
                    handleSave={this.createOrganizationPerson}
                    handleCancel={() => this.setState({ addingNew: false })}
                    t={this.props.t}
                    saveDisabled={!this.state.newOrganization}
                    style={{ marginTop: "8px" }}
                  />
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    );
  }
}
