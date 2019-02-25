import {
  SET_ORGANIZATIONS,
  ADD_ORGANIZATION,
  SET_ORGANIZATION,
  DELETE_ORGANIZATION,
  ADD_ORGANIZATIONS,
  OrganizationAction
} from "../actions/organizationActions";
import { organizationCompare } from "../models/organization";
import { IOrganization } from "../models/TypeBucket";
import { stdReducers } from "./stdReducers";

const emptyOrganization: IOrganization = {
  id: 0,
  name: ""
};

export interface OrganizationState {
  list: number[];
  byId: { [id: string]: IOrganization | undefined };
}

const emptyState: OrganizationState = {
  list: [],
  byId: {}
};

const stdOrganizationReducers = stdReducers(
  emptyOrganization,
  organizationCompare
);

export default function organizationsReducer(
  state = emptyState,
  action: OrganizationAction
) {
  switch (action.type) {
    case SET_ORGANIZATIONS:
      return stdOrganizationReducers.setList(state, action.organizations!);
    case ADD_ORGANIZATIONS:
      return stdOrganizationReducers.addItems(state, action.organizations!);
    case ADD_ORGANIZATION:
      return stdOrganizationReducers.addItems(state, [action.organization!]);
    case SET_ORGANIZATION:
      return stdOrganizationReducers.addItems(state, [action.organization!]);
    case DELETE_ORGANIZATION:
      return stdOrganizationReducers.deleteItem(state, action.id!);
  }
  return state;
}