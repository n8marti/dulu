import baseCompare from "../util/baseCompare";
import { ICan } from "../actions/canActions";

export interface IOrganization {
  id: number;
  short_name: string;
  long_name: string;
  description: string;
  parent_id: number | null;
  country: { name: string } | null;
  can: ICan;
  country_id?: number;
}

export interface IOrganizationPerson {
  id: number;
  person_id: number;
  organization_id: number;
  position?: string;
  start_date?: string;
  end_date?: string;
}

function compare(a: IOrganization, b: IOrganization) {
  const nameComparison = baseCompare(a.short_name, b.short_name);
  if (nameComparison != 0) return nameComparison;
  return b.id - a.id;
}

export default {
  compare
};